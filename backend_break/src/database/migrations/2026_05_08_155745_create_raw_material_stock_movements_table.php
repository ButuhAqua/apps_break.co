<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('raw_material_stock_movements', function (Blueprint $table) {
            $table->id();

            $table->foreignId('raw_material_id')
                ->constrained('raw_materials')
                ->cascadeOnDelete();

            $table->unsignedBigInteger('raw_material_inventory_batch_id')->nullable();

            $table->foreign('raw_material_inventory_batch_id', 'rm_stock_batch_fk')
                ->references('id')
                ->on('raw_material_inventory_batches')
                ->nullOnDelete();

            $table->string('type'); 
            // IN, OUT, ADJUSTMENT, EXPIRED

            $table->integer('qty');

            $table->string('uom');

            $table->string('reference_type')->nullable();
            // RawMaterialRequest, ProductionReport, ManualAdjustment

            $table->unsignedBigInteger('reference_id')->nullable();

            $table->text('notes')->nullable();

            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('raw_material_stock_movements');
    }
};