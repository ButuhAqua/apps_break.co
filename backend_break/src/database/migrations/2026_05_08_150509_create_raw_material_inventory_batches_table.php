<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('raw_material_inventory_batches', function (Blueprint $table) {
            $table->id();

            $table->foreignId('raw_material_id')
                ->constrained('raw_materials')
                ->cascadeOnDelete();

            $table->string('batch_number')->unique();

            $table->date('received_date');
            $table->date('expired_date')->nullable();

            $table->integer('qty_in');
            $table->integer('qty_remaining');

            $table->string('uom');
            $table->string('supplier')->nullable();
            $table->text('notes')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('raw_material_inventory_batches');
    }
};