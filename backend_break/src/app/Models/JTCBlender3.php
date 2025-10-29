<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class JTCBlender3 extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'feature_of_product',
        'product_dimensions',
        'packing',
        'product_specification',
        'image1',
        'image2',
    ];
}
