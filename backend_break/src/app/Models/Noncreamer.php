<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Noncreamer extends Model
{
    protected $fillable = [
        'name',
        'expired',
        'product_details',
        'ingredients',
        'product_characteristics',
        'image',
    ];
}
