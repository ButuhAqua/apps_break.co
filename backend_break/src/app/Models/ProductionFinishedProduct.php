<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductionFinishedProduct extends Model
{
    use HasFactory;

    protected $fillable = [
        'production_report_id',
        'product_id',
        'qty',
        'uom',
    ];

    public function productionReport()
    {
        return $this->belongsTo(ProductionReport::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}