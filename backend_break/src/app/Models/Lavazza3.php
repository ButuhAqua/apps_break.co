<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lavazza3 extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'size', 'description', 'case_quantity', 'image'];
}
