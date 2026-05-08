<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductionMaterialUsage extends Model
{
    use HasFactory;

    protected $fillable = [
        'production_report_id',
        'raw_material_id',
        'qty',
        'uom',
    ];

    public function productionReport()
    {
        return $this->belongsTo(ProductionReport::class);
    }

    public function rawMaterial()
    {
        return $this->belongsTo(RawMaterial::class);
    }
}