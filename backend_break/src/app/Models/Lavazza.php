<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lavazza extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'size', 'description', 'case_quantity', 'image'];
}
