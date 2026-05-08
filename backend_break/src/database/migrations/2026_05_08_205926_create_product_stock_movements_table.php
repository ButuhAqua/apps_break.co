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
        Schema::create('product_stock_movements', function (Blueprint $table) {
            $table->id();
        
            $table->foreignId('product_id')
                ->constrained()
                ->cascadeOnDelete();
        
            $table->string('type'); 
            // IN, OUT, TRANSFER
        
            $table->integer('qty');
            $table->string('uom');
        
            $table->string('from_location')->nullable();
            $table->string('to_location')->nullable();
        
            $table->string('reference_type')->nullable();
            $table->unsignedBigInteger('reference_id')->nullable();
        
            $table->text('notes')->nullable();
        
            $table->foreignId('user_id')
                ->nullable()
                ->constrained()
                ->nullOnDelete();
        
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_stock_movements');
    }
};
