<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SliderIndex extends Model
{
    protected $table = 'sliders';

    protected $fillable = [
        'image',
        'title',
        'description',
    ];
}
