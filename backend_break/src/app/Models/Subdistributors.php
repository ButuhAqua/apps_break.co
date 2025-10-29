<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Subdistributors extends Model
{
    use HasFactory;

    protected $fillable = [
        'kota', 
        'nama_pt', 
        'alamat', 
        'nomor_telp1',
        'nomor_telp2',
        'email1',
        'email2'
    ];
}
