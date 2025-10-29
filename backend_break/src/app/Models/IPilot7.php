<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IPilot7 extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'feature_of_product',
        'product_dimensions',
        'product_specification',
        'image1',
        'image2',
    ];
}
