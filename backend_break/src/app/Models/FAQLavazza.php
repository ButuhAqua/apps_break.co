<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FAQLavazza extends Model
{
    use HasFactory;

    protected $table = 'f_a_q_lavazzas';

    protected $fillable = [
        'question',
        'answer',
    ];
}
