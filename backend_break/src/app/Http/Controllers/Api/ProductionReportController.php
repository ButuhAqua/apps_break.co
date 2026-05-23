<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductionReport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Inventory;
use App\Models\ProductInventoryBatch;
use App\Models\ProductStockMovement;

class ProductionReportController extends Controller
{
    public function index()
    {
        $reports = ProductionReport::with([
                'materialUsages.rawMaterial',
                'finishedProducts.product',
                'user',
            ])
            ->latest()
            ->get();

        return response()->json([
            'data' => $reports,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'report_number' => [
                'nullable',
                'string',
                'max:255',
                'unique:production_reports,report_number'
            ],

            'production_date' => ['required', 'date'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],

            'material_usages' => ['required', 'array', 'min:1'],
            'material_usages.*.raw_material_id' => [
                'required',
                'exists:raw_materials,id'
            ],
            'material_usages.*.qty' => [
                'required',
                'integer',
                'min:1'
            ],
            'material_usages.*.uom' => [
                'required',
                'string',
                'max:50'
            ],

            'finished_products' => ['required', 'array', 'min:1'],
            'finished_products.*.product_id' => [
                'required',
                'exists:products,id'
            ],
            'finished_products.*.qty' => [
                'required',
                'integer',
                'min:1'
            ],
            'finished_products.*.uom' => [
                'required',
                'string',
                'max:50'
            ],
        ]);

        $report = DB::transaction(function () use (
            $validated,
            $request
        ) {

            $report = ProductionReport::create([
                'report_number' =>
                    $validated['report_number']
                    ?? $this->generateReportNumber(),

                'production_date' =>
                    $validated['production_date'],

                'status' =>
                    $validated['status']
                    ?? 'Submitted',

                'notes' =>
                    $validated['notes'] ?? null,

                'user_id' =>
                    $request->user()?->id,
            ]);

            foreach ($validated['material_usages'] as $item) {

                $report->materialUsages()->create([
                    'raw_material_id' => $item['raw_material_id'],
                    'qty' => $item['qty'],
                    'uom' => $item['uom'],
                ]);
            }

            foreach ($validated['finished_products'] as $item) {

                $report->finishedProducts()->create([
                    'product_id' => $item['product_id'],
                    'qty' => $item['qty'],
                    'uom' => $item['uom'],
                ]);
            }

            return $report->load([
                'materialUsages.rawMaterial',
                'finishedProducts.product',
                'user',
            ]);
        });

        return response()->json([
            'message' => 'Laporan produksi berhasil dibuat',
            'data' => $report,
        ], 201);
    }

    public function show(
        ProductionReport $productionReport
    ) {

        $productionReport->load([
            'materialUsages.rawMaterial',
            'finishedProducts.product',
            'user',
        ]);

        return response()->json([
            'data' => $productionReport,
        ]);
    }

    private function generateReportNumber(): string
    {
        $date = now()->format('Ymd');

        $prefix = "PRD-{$date}";

        $number = ProductionReport::where(
                'report_number',
                'like',
                "{$prefix}-%"
            )
            ->count() + 1;

        do {

            $reportNumber =
                "{$prefix}-" .
                str_pad($number, 3, '0', STR_PAD_LEFT);

            $number++;

        } while (
            ProductionReport::where(
                'report_number',
                $reportNumber
            )->exists()
        );

        return $reportNumber;
    }

    public function approve(
        Request $request,
        ProductionReport $productionReport
    ) {

        $user = $request->user()->load('employee');

        $allowedRoles = [
            'Manager',
            'Owner',
            'Admin'
        ];

        if (!in_array(
            $user->employee?->role,
            $allowedRoles
        )) {

            return response()->json([
                'message' => 'Tidak memiliki akses approval'
            ], 403);
        }

        // hanya Submitted yang boleh diapprove
        if ($productionReport->status !== 'Submitted') {

            return response()->json([
                'message' => 'Laporan sudah diproses sebelumnya'
            ], 422);
        }

        $productionReport->update([
            'status' => 'Disetujui',
        ]);

        return response()->json([
            'message' => 'Laporan produksi berhasil disetujui',
            'data' => $productionReport->fresh(),
        ]);
    }

    public function complete(
        Request $request,
        ProductionReport $productionReport
    ) {

        $user = $request->user()->load('employee');

        $allowedRoles = [
            'Manager',
            'Owner',
            'Admin'
        ];

        if (!in_array(
            $user->employee?->role,
            $allowedRoles
        )) {

            return response()->json([
                'message' =>
                    'Tidak memiliki akses menyelesaikan laporan'
            ], 403);
        }

        // hanya Disetujui yang bisa diselesaikan
        if ($productionReport->status !== 'Disetujui') {

            return response()->json([
                'message' =>
                    'Laporan harus disetujui terlebih dahulu'
            ], 422);
        }

        $validated = $request->validate([

            'items' => ['required', 'array', 'min:1'],
        
            'items.*.product_id' => [
                'required',
                'exists:products,id',
            ],
        
            'items.*.expired_date' => [
                'required',
                'date',
            ],
        ]);

        DB::beginTransaction();

        try {

            $productionReport->load([
                'materialUsages.rawMaterial',
                'finishedProducts.product',
            ]);

            foreach (
                $productionReport->materialUsages
                as $usage
            ) {

                $remainingQtyToTake = $usage->qty;

                $availableStock =
                    \App\Models\RawMaterialInventoryBatch::query()
                        ->where(
                            'raw_material_id',
                            $usage->raw_material_id
                        )
                        ->where('qty_remaining', '>', 0)
                        ->sum('qty_remaining');

                if ($availableStock < $usage->qty) {

                    throw new \Exception(
                        'Stok bahan "' .
                        ($usage->rawMaterial?->name ?? '-') .
                        '" tidak cukup.'
                    );
                }

                $batches =
                    \App\Models\RawMaterialInventoryBatch::query()
                        ->where(
                            'raw_material_id',
                            $usage->raw_material_id
                        )
                        ->where('qty_remaining', '>', 0)
                        ->orderBy('expired_date')
                        ->orderBy('received_date')
                        ->lockForUpdate()
                        ->get();

                foreach ($batches as $batch) {

                    if ($remainingQtyToTake <= 0) {
                        break;
                    }

                    $takenQty = min(
                        $remainingQtyToTake,
                        $batch->qty_remaining
                    );

                    $batch->update([
                        'qty_remaining' =>
                            $batch->qty_remaining - $takenQty,
                    ]);

                    \App\Models\RawMaterialStockMovement::create([
                        'raw_material_id' =>
                            $usage->raw_material_id,

                        'raw_material_inventory_batch_id' =>
                            $batch->id,

                        'type' => 'OUT',

                        'qty' => $takenQty,

                        'uom' => $usage->uom,

                        'reference_type' =>
                            ProductionReport::class,

                        'reference_id' =>
                            $productionReport->id,

                        'notes' =>
                            'Stock keluar otomatis dari laporan produksi #' .
                            $productionReport->id,

                        'user_id' => $user->id,
                    ]);

                    $remainingQtyToTake -= $takenQty;
                }
            }

            foreach (
                $productionReport->finishedProducts
                as $finishedProduct
            ) {

                $inventory = Inventory::firstOrCreate(
                    [
                        'product_id' =>
                            $finishedProduct->product_id,

                        'location' => 'Basecamp',
                    ],
                    [
                        'stock' => 0,
                    ]
                );

                $inventory->increment(
                    'stock',
                    $finishedProduct->qty
                );

                $productExpired =
                    collect($validated['items'])
                        ->firstWhere(
                            'product_id',
                            $finishedProduct->product_id
                        );

                if (!$productExpired) {

                    throw new \Exception(
                        'Expired produk tidak ditemukan'
                    );
                }

                ProductInventoryBatch::create([

                    'product_id' =>
                        $finishedProduct->product_id,

                    'inventory_id' =>
                        $inventory->id,

                    'batch_number' =>
                        'PRD-' .
                        now()->format('YmdHis') .
                        '-' .
                        $finishedProduct->product_id,

                    'production_date' =>
                        $productionReport->production_date,

                    'expired_date' =>
                        $productExpired['expired_date'],

                    'qty_in' =>
                        $finishedProduct->qty,

                    'qty_remaining' =>
                        $finishedProduct->qty,

                    'uom' =>
                        $finishedProduct->uom,

                    'notes' =>
                        'Batch produk dari produksi #' .
                        $productionReport->id,
                ]);

                ProductStockMovement::create([
                    'product_id' =>
                        $finishedProduct->product_id,

                    'type' => 'IN',

                    'qty' =>
                        $finishedProduct->qty,

                    'uom' =>
                        $finishedProduct->uom,

                    'from_location' => null,

                    'to_location' => 'Basecamp',

                    'reference_type' =>
                        ProductionReport::class,

                    'reference_id' =>
                        $productionReport->id,

                    'notes' =>
                        'Produk masuk otomatis dari laporan produksi #' .
                        $productionReport->id,

                    'user_id' => $user->id,
                ]);
            }

            $productionReport->update([
                'status' => 'Selesai',
            ]);

            DB::commit();

            if (!$request->expectsJson()) {
                return true;
            }

            return response()->json([
                'message' =>
                    'Laporan produksi berhasil diselesaikan',

                'data' => $productionReport->fresh(),
            ]);

        } catch (\Throwable $e) {

            DB::rollBack();
        
            throw $e;
        }
    }

    public function reject(
        Request $request,
        ProductionReport $productionReport
    ) {

        $user = $request->user()->load('employee');

        $allowedRoles = [
            'Manager',
            'Owner',
            'Admin'
        ];

        if (!in_array(
            $user->employee?->role,
            $allowedRoles
        )) {

            return response()->json([
                'message' => 'Tidak memiliki akses approval'
            ], 403);
        }

        // hanya Submitted / Disetujui yang boleh ditolak
        if (!in_array(
            $productionReport->status,
            ['Submitted', 'Disetujui']
        )) {

            return response()->json([
                'message' => 'Laporan tidak bisa ditolak',
            ], 422);
        }

        $validated = $request->validate([
            'reason' => 'nullable|string|max:255',
        ]);

        $productionReport->update([
            'status' => 'Ditolak',

            'notes' =>
                $validated['reason']
                ?? $productionReport->notes,
        ]);

        return response()->json([
            'message' => 'Laporan produksi berhasil ditolak',
        ]);
    }
}