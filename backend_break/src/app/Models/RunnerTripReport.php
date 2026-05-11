<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RunnerTripReport extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'location',
        'departure_at',
        'return_at',
        'status',
        'notes',
    ];

    protected $casts = [
        'departure_at' => 'datetime',
        'return_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(RunnerTripItem::class);
    }
}