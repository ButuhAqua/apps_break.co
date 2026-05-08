<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductionReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'report_number',
        'production_date',
        'status',
        'notes',
        'user_id',
    ];

    protected $casts = [
        'production_date' => 'date',
    ];

    public function materialUsages()
    {
        return $this->hasMany(ProductionMaterialUsage::class);
    }

    public function finishedProducts()
    {
        return $this->hasMany(ProductionFinishedProduct::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}