<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RawMaterialRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'request_type',
        'priority',
        'request_date',
        'notes',
        'purchase_location',
        'status',
        'user_id',
    ];

    public function items()
    {
        return $this->hasMany(RawMaterialRequestItem::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}