<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RawMaterial;

class RawMaterialInventoryController extends Controller
{
    public function index()
    {
        $materials = RawMaterial::with([
            'inventoryBatches' => function ($query) {
                $query
                    ->where('qty_remaining', '>', 0)
                    ->orderBy('expired_date');
            }
        ])
            ->orderBy('name')
            ->get();

        $data = $materials->map(function ($material) {
            $activeBatches = $material->inventoryBatches;

            return [
                'raw_material_id' => $material->id,
                'name' => $material->name,
                'category' => $material->category,
                'uom' => $material->uom,
                'total_stock' => $activeBatches->sum('qty_remaining'),
                'batch_count' => $activeBatches->count(),
                'nearest_expired_date' => optional($activeBatches->first())->expired_date,
                'batches' => $activeBatches->map(function ($batch) {
                    return [
                        'id' => $batch->id,
                        'batch_number' => $batch->batch_number,
                        'received_date' => $batch->received_date,
                        'expired_date' => $batch->expired_date,
                        'qty_in' => $batch->qty_in,
                        'qty_remaining' => $batch->qty_remaining,
                        'uom' => $batch->uom,
                        'supplier' => $batch->supplier,
                        'status' => $this->getBatchStatus($batch),
                    ];
                })->values(),
            ];
        });

        return response()->json([
            'data' => $data,
        ]);
    }

    private function getBatchStatus($batch): string
    {
        if ($batch->qty_remaining <= 0) {
            return 'Habis';
        }

        if ($batch->expired_date && $batch->expired_date->isPast()) {
            return 'Expired';
        }

        if (
            $batch->expired_date &&
            now()->lte($batch->expired_date) &&
            now()->diffInDays($batch->expired_date) <= 7
        ) {
            return 'Hampir Expired';
        }

        return 'Aman';
    }
}