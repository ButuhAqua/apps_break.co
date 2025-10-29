<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TipsInner2 extends Model
{
    protected $fillable = [
        'title',
        'capacity',
        'ingredients',
        'instruction',
        'image',
    ];
}
