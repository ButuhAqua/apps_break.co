<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\RawMaterialStockMovement;

class RawMaterialInventoryBatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'raw_material_id',
        'batch_number',
        'received_date',
        'expired_date',
        'qty_in',
        'qty_remaining',
        'uom',
        'supplier',
        'notes',
    ];

    protected $casts = [
        'received_date' => 'date',
        'expired_date' => 'date',
    ];

    public function rawMaterial()
    {
        return $this->belongsTo(RawMaterial::class);
    }

    public function stockMovements()
    {
        return $this->hasMany(
            RawMaterialStockMovement::class,
            'raw_material_inventory_batch_id'
        );
    }
}