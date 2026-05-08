<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inventory;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    public function index(Request $request)
    {
        $location = $request->location;

        $data = Inventory::with('product')
            ->where('location', $location)
            ->get();

        return response()->json(
            $data->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->product->name,
                    'sku' => $item->product->sku,
                    'uom' => $item->product->uom,
                    'qty' => $item->stock,
                    'min_qty' => $item->product->min_stock,
                    'location' => $item->location,
                    'last_updated' => $item->updated_at,
                ];
            })
        );
    }
}
