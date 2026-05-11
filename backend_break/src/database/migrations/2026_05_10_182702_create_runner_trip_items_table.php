<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('runner_trip_items', function (Blueprint $table) {
            $table->id();

            $table->foreignId('runner_trip_report_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('product_id')
                ->constrained()
                ->cascadeOnDelete();

            // qty dibawa
            $table->integer('qty_taken');

            // qty kembali
            $table->integer('qty_returned')
                ->nullable();

            // auto calculate
            $table->integer('qty_sold')
                ->default(0);

            $table->string('uom');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('runner_trip_items');
    }
};