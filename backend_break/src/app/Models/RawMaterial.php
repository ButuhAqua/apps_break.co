<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\RawMaterialStockMovement;

class RawMaterial extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'uom',
        'stock',
        'is_active',
    ];

    public function requestItems()
    {
        return $this->hasMany(RawMaterialRequestItem::class);
    }

    public function inventoryBatches()
    {
        return $this->hasMany(RawMaterialInventoryBatch::class);
    }

    public function stockMovements()
    {
        return $this->hasMany(RawMaterialStockMovement::class);
    }

    public function productionMaterialUsages()
    {
        return $this->hasMany(ProductionMaterialUsage::class);
    }
}