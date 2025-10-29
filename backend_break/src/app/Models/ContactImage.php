<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ContactImage extends Model
{
    use HasFactory;

    protected $fillable = ['image'];
}
