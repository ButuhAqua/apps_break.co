<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RawMaterialStockMovement extends Model
{
    use HasFactory;

    protected $fillable = [
        'raw_material_id',
        'raw_material_inventory_batch_id',
        'type',
        'qty',
        'uom',
        'reference_type',
        'reference_id',
        'notes',
        'user_id',
    ];

    public function rawMaterial()
    {
        return $this->belongsTo(RawMaterial::class);
    }

    public function batch()
    {
        return $this->belongsTo(
            RawMaterialInventoryBatch::class,
            'raw_material_inventory_batch_id'
        );
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}