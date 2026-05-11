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
        Schema::create('employees', function (Blueprint $table) {
            $table->id();
        
            $table->foreignId('user_id')
                ->unique()
                ->constrained()
                ->cascadeOnDelete();
        
            $table->string('employee_code')->unique();
            $table->string('full_name');
        
            $table->string('role');
            // Admin, Owner, Manager, Unit Produksi, Runner
        
            $table->string('assigned_location')->nullable();
            // Basecamp, Gerobak A, Gerobak B
        
            $table->string('status')->default('Aktif');
            // Aktif, Nonaktif
        
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('employees');
    }
};
