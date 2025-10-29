<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TipsInner3 extends Model
{
    protected $fillable = [
        'title',
        'capacity',
        'ingredients',
        'garnish',
        'instruction',
        'image',
    ];
}
