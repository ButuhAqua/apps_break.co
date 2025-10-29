<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Commisioner extends Model
{
    use HasFactory;

    protected $fillable = [
        'division',
        'image',
        'name',
        'jabatan',
        'short_description',
        'previous_positions',
        'position_period'
    ];

    protected $casts = [
        'position_period' => 'array', // Cast otomatis JSON ke array
    ];
}
