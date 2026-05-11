<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RunnerTripItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'runner_trip_report_id',
        'product_id',
        'qty_taken',
        'qty_returned',
        'qty_sold',
        'uom',
    ];

    public function trip()
    {
        return $this->belongsTo(RunnerTripReport::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}