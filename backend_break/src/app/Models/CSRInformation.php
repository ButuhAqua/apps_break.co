<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CSRInformation extends Model
{
    protected $fillable = [
        'tahun_csr',
        'judul_csr',
        'deskripsi',
        'gambar_utama',
        'gambar_pendukung',
    ];
}
