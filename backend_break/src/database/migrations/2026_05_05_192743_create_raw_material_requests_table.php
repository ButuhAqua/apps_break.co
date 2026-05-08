<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('raw_material_requests', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('request_type')->default('Pembelian Bahan Baku');
            $table->string('priority')->default('Normal');
            $table->date('request_date');
            $table->text('notes')->nullable();
            $table->string('purchase_location')->nullable();
            $table->string('status')->default('Menunggu');
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('raw_material_requests');
    }
};