<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inventory;
use App\Models\ProductStockMovement;
use App\Models\RunnerTripItem;
use App\Models\RunnerTripReport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RunnerTripController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user()->load('employee');

        $query = RunnerTripReport::with(['items.product', 'user'])
            ->latest();

        if ($user->employee?->role === 'Runner') {
            $query->where('user_id', $user->id);
        }

        return response()->json([
            'data' => $query->get(),
        ]);
    }

    public function storeDeparture(Request $request)
    {
        $user = $request->user()->load('employee');

        if (!$user->employee) {
            return response()->json([
                'message' => 'Employee profile tidak ditemukan',
            ], 422);
        }

        if ($user->employee->role !== 'Runner') {
            return response()->json([
                'message' => 'Hanya runner yang bisa membuat laporan berangkat',
            ], 403);
        }

        $location = $user->employee->assigned_location;

        if (!$location) {
            return response()->json([
                'message' => 'Runner belum memiliki assigned location',
            ], 422);
        }

        $hasActiveTrip = RunnerTripReport::where('user_id', $user->id)
            ->whereIn('status', [
                'PENDING_DEPARTURE',
                'ONGOING',
                'PENDING_RETURN',
            ])
            ->exists();

        if ($hasActiveTrip) {
            return response()->json([
                'message' => 'Masih ada trip yang belum selesai. Selesaikan proses approval terlebih dahulu.',
            ], 422);
        }

        $validated = $request->validate([
            'notes' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty_taken' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $trip = DB::transaction(function () use ($validated, $user, $location) {
                $trip = RunnerTripReport::create([
                    'user_id' => $user->id,
                    'location' => $location,
                    'departure_at' => now(),
                    'return_at' => null,
                    'status' => 'PENDING_DEPARTURE',
                    'notes' => $validated['notes'] ?? null,
                ]);

                foreach ($validated['items'] as $item) {
                    $inventory = Inventory::with('product')
                        ->where('product_id', $item['product_id'])
                        ->where('location', $location)
                        ->first();

                    if (!$inventory) {
                        throw new \Exception('Inventory produk tidak ditemukan untuk produk ID: ' . $item['product_id']);
                    }

                    if ($inventory->stock < $item['qty_taken']) {
                        throw new \Exception(
                            'Stok tidak cukup untuk produk ' .
                            ($inventory->product?->name ?? 'ID ' . $item['product_id']) .
                            '. Tersedia ' . $inventory->stock .
                            ', diminta ' . $item['qty_taken'] . '.'
                        );
                    }

                    RunnerTripItem::create([
                        'runner_trip_report_id' => $trip->id,
                        'product_id' => $item['product_id'],
                        'qty_taken' => $item['qty_taken'],
                        'qty_returned' => null,
                        'qty_sold' => 0,
                        'uom' => $inventory->product?->uom ?? 'pcs',
                    ]);
                }

                return $trip->load(['items.product', 'user']);
            });

            return response()->json([
                'message' => 'Laporan berangkat berhasil dibuat dan menunggu approval',
                'data' => $trip,
            ], 201);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function storeReturn(Request $request, RunnerTripReport $runnerTripReport)
    {
        $user = $request->user()->load('employee');

        if (!$user->employee) {
            return response()->json([
                'message' => 'Employee profile tidak ditemukan',
            ], 422);
        }

        if ($user->employee->role !== 'Runner') {
            return response()->json([
                'message' => 'Hanya runner yang bisa membuat laporan pulang',
            ], 403);
        }

        if ($runnerTripReport->user_id !== $user->id) {
            return response()->json([
                'message' => 'Anda tidak boleh menyelesaikan trip milik user lain',
            ], 403);
        }

        if ($runnerTripReport->status !== 'ONGOING') {
            return response()->json([
                'message' => 'Laporan pulang hanya bisa dibuat setelah laporan berangkat disetujui',
            ], 422);
        }

        $validated = $request->validate([
            'notes' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.runner_trip_item_id' => ['required', 'exists:runner_trip_items,id'],
            'items.*.qty_returned' => ['required', 'integer', 'min:0'],
        ]);

        try {
            $trip = DB::transaction(function () use ($runnerTripReport, $validated) {
                foreach ($validated['items'] as $item) {
                    $tripItem = RunnerTripItem::where('id', $item['runner_trip_item_id'])
                        ->where('runner_trip_report_id', $runnerTripReport->id)
                        ->firstOrFail();

                    if ($item['qty_returned'] > $tripItem->qty_taken) {
                        throw new \Exception('Qty kembali tidak boleh lebih besar dari qty dibawa.');
                    }

                    $qtySold = $tripItem->qty_taken - $item['qty_returned'];

                    $tripItem->update([
                        'qty_returned' => $item['qty_returned'],
                        'qty_sold' => $qtySold,
                    ]);
                }

                $runnerTripReport->update([
                    'return_at' => now(),
                    'status' => 'PENDING_RETURN',
                    'notes' => $validated['notes'] ?? $runnerTripReport->notes,
                ]);

                return $runnerTripReport->load(['items.product', 'user']);
            });

            return response()->json([
                'message' => 'Laporan pulang berhasil dibuat dan menunggu approval',
                'data' => $trip,
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function approveDeparture(Request $request, RunnerTripReport $runnerTripReport)
    {
        $user = $request->user()->load('employee');

        if (!$this->canApprove($user)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval',
            ], 403);
        }

        if ($runnerTripReport->status !== 'PENDING_DEPARTURE') {
            return response()->json([
                'message' => 'Laporan berangkat tidak dalam status menunggu approval',
            ], 422);
        }

        $runnerTripReport->update([
            'status' => 'ONGOING',
        ]);

        return response()->json([
            'message' => 'Laporan berangkat disetujui',
            'data' => $runnerTripReport->load(['items.product', 'user']),
        ]);
    }

    public function rejectDeparture(Request $request, RunnerTripReport $runnerTripReport)
    {
        $user = $request->user()->load('employee');

        if (!$this->canApprove($user)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval',
            ], 403);
        }

        if ($runnerTripReport->status !== 'PENDING_DEPARTURE') {
            return response()->json([
                'message' => 'Laporan berangkat tidak dalam status menunggu approval',
            ], 422);
        }

        $runnerTripReport->update([
            'status' => 'REJECTED_DEPARTURE',
            'notes' => $request->input('reason', $runnerTripReport->notes),
        ]);

        return response()->json([
            'message' => 'Laporan berangkat ditolak',
            'data' => $runnerTripReport->load(['items.product', 'user']),
        ]);
    }

    public function approveReturn(Request $request, RunnerTripReport $runnerTripReport)
    {
        $user = $request->user()->load('employee');

        if (!$this->canApprove($user)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval',
            ], 403);
        }

        if ($runnerTripReport->status !== 'PENDING_RETURN') {
            return response()->json([
                'message' => 'Laporan pulang tidak dalam status menunggu approval',
            ], 422);
        }

        try {
            $trip = DB::transaction(function () use ($runnerTripReport, $user) {
                $runnerTripReport->load('items.product');

                foreach ($runnerTripReport->items as $item) {
                    if ($item->qty_sold <= 0) {
                        continue;
                    }

                    $inventory = Inventory::where('product_id', $item->product_id)
                        ->where('location', $runnerTripReport->location)
                        ->lockForUpdate()
                        ->first();

                    if (!$inventory) {
                        throw new \Exception('Inventory produk tidak ditemukan untuk approval pulang.');
                    }

                    if ($inventory->stock < $item->qty_sold) {
                        throw new \Exception(
                            'Stok tidak cukup. Produk ' .
                            ($item->product?->name ?? 'ID ' . $item->product_id) .
                            ', stok tersedia ' . $inventory->stock .
                            ', qty terjual ' . $item->qty_sold . '.'
                        );
                    }

                    $inventory->decrement('stock', $item->qty_sold);

                    ProductStockMovement::create([
                        'product_id' => $item->product_id,
                        'type' => 'OUT',
                        'qty' => $item->qty_sold,
                        'uom' => $item->uom,
                        'from_location' => $runnerTripReport->location,
                        'to_location' => null,
                        'reference_type' => RunnerTripReport::class,
                        'reference_id' => $runnerTripReport->id,
                        'notes' => 'Produk terjual otomatis dari approval laporan pulang trip #' . $runnerTripReport->id,
                        'user_id' => $user->id,
                    ]);
                }

                $runnerTripReport->update([
                    'status' => 'FINISHED',
                ]);

                return $runnerTripReport->load(['items.product', 'user']);
            });

            return response()->json([
                'message' => 'Laporan pulang disetujui',
                'data' => $trip,
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function rejectReturn(Request $request, RunnerTripReport $runnerTripReport)
    {
        $user = $request->user()->load('employee');

        if (!$this->canApprove($user)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval',
            ], 403);
        }

        if ($runnerTripReport->status !== 'PENDING_RETURN') {
            return response()->json([
                'message' => 'Laporan pulang tidak dalam status menunggu approval',
            ], 422);
        }

        $runnerTripReport->update([
            'status' => 'REJECTED_RETURN',
            'notes' => $request->input('reason', $runnerTripReport->notes),
        ]);

        return response()->json([
            'message' => 'Laporan pulang ditolak',
            'data' => $runnerTripReport->load(['items.product', 'user']),
        ]);
    }

    private function canApprove($user): bool
    {
        return in_array($user->employee?->role, [
            'Manager',
            'Owner',
            'Admin',
        ]);
    }
}