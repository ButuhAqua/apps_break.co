<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('raw_material_request_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('raw_material_request_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->string('name');
            $table->string('category')->default('Bahan Baku');
            $table->string('uom');
            $table->integer('qty');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('raw_material_request_items');
    }
};