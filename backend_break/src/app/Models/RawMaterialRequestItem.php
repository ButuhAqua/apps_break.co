<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RawMaterialRequestItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'raw_material_request_id',
        'raw_material_id',
        'name',
        'category',
        'uom',
        'qty',
    ];

    public function rawMaterialRequest()
    {
        return $this->belongsTo(\App\Models\RawMaterialRequest::class);
    }

    public function rawMaterial()
    {
        return $this->belongsTo(RawMaterial::class);
    }
}