<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Creamer extends Model
{
    protected $fillable = [
        'name',
        'size',
        'detail_size',
        'expired',
        'product_details',
        'ingredients',
        'product_characteristics',
        'image',
    ];
}
