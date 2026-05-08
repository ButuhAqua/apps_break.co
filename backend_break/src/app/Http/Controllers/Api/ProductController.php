<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        return response()->json([
            'data' => Product::query()
                ->orderBy('name')
                ->get([
                    'id',
                    'name',
                    'sku',
                    'uom',
                    'min_stock',
                ]),
        ]);
    }
}