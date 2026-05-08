<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RawMaterial;

class RawMaterialController extends Controller
{
    public function index()
    {
        $materials = RawMaterial::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get([
                'id',
                'name',
                'category',
                'uom',
                'stock',
            ]);

        return response()->json([
            'data' => $materials,
        ]);
    }
}