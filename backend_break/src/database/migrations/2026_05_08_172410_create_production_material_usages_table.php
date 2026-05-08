<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('production_material_usages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('production_report_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('raw_material_id')
                ->constrained('raw_materials')
                ->cascadeOnDelete();

            $table->integer('qty');
            $table->string('uom');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('production_material_usages');
    }
};
