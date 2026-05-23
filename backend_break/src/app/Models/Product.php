<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'sku',
        'uom',
        'min_stock',
    ];

    public function inventories()
    {
        return $this->hasMany(Inventory::class);
    }

    public function productionFinishedProducts()
    {
        return $this->hasMany(ProductionFinishedProduct::class);
    }

    public function stockMovements()
    {
        return $this->hasMany(ProductStockMovement::class);
    }

    public function inventoryBatches()
    {
        return $this->hasMany(
            ProductInventoryBatch::class
        );
    }
}