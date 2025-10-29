<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = ['name'];

    public function syrups()
    {
        return $this->hasMany(Syrup::class);
    }

    public function sauces()
    {
        return $this->hasMany(Sauce::class);
    }

    public function frappes()
    {
        return $this->hasMany(Frappe::class);
    }

    public function fruitmixes()
    {
        return $this->hasMany(Frappe::class);
    }
}
