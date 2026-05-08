<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductionReport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
            'report_number' => ['nullable', 'string', 'max:255', 'unique:production_reports,report_number'],
            'production_date' => ['required', 'date'],
            'status' => ['nullable', 'string', 'max:255'],
            'notes' => ['nullable', 'string'],

            'material_usages' => ['required', 'array', 'min:1'],
            'material_usages.*.raw_material_id' => ['required', 'exists:raw_materials,id'],
            'material_usages.*.qty' => ['required', 'integer', 'min:1'],
            'material_usages.*.uom' => ['required', 'string', 'max:50'],

            'finished_products' => ['required', 'array', 'min:1'],
            'finished_products.*.product_id' => ['required', 'exists:products,id'],
            'finished_products.*.qty' => ['required', 'integer', 'min:1'],
            'finished_products.*.uom' => ['required', 'string', 'max:50'],
        ]);

        $report = DB::transaction(function () use ($validated, $request) {
            $report = ProductionReport::create([
                'report_number' => $validated['report_number'] ?? $this->generateReportNumber(),
                'production_date' => $validated['production_date'],
                'status' => $validated['status'] ?? 'Submitted',
                'notes' => $validated['notes'] ?? null,
                'user_id' => $request->user()?->id,
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

    public function show(ProductionReport $productionReport)
    {
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

        $number = ProductionReport::where('report_number', 'like', "{$prefix}-%")
            ->count() + 1;

        do {
            $reportNumber = "{$prefix}-" . str_pad($number, 3, '0', STR_PAD_LEFT);
            $number++;
        } while (ProductionReport::where('report_number', $reportNumber)->exists());

        return $reportNumber;
    }
}