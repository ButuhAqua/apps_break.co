<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductInventoryBatch extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'inventory_id',
        'batch_number',
        'production_date',
        'expired_date',
        'qty_in',
        'qty_remaining',
        'uom',
        'notes',
    ];

    protected $casts = [
        'production_date' => 'date',
        'expired_date' => 'date',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function inventory()
    {
        return $this->belongsTo(Inventory::class);
    }
}