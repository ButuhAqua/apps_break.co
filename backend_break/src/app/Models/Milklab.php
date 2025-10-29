<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Milklab extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'size', 'description', 'product_info', 'image', 'color_code'];

    // Mengonversi product_info menjadi array saat ditampilkan
    public function getProductInfoArrayAttribute()
    {
        return explode("\n", $this->product_info);
    }

    // Menyimpan product_info sebagai string dengan pemisah newline (\n)
    public function setProductInfoAttribute($value)
    {
        if (is_array($value)) {
            $this->attributes['product_info'] = implode("\n", array_map('trim', $value));
        } else {
            $this->attributes['product_info'] = trim($value);
        }
    }

    // Mengonversi description menjadi array saat ditampilkan
    public function getDescriptionArrayAttribute()
    {
        return explode("\n", $this->description);
    }

    // Menyimpan description sebagai string dengan pemisah newline (\n)
    public function setDescriptionAttribute($value)
    {
        if (is_array($value)) {
            $this->attributes['description'] = implode("\n", array_map('trim', $value));
        } else {
            $this->attributes['description'] = trim($value);
        }
    }
}
