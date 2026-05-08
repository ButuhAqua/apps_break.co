<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\RawMaterialRequestController;
use App\Http\Controllers\Api\RawMaterialController;
use App\Http\Controllers\Api\RawMaterialInventoryController;
use App\Http\Controllers\Api\ProductionReportController;
use App\Http\Controllers\Api\ProductController;


// PUBLIC ROUTE
Route::post('/login', [AuthController::class, 'login']);

// PROTECTED ROUTES
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::get('/inventory', [InventoryController::class, 'index']);
    Route::get('/raw-material-requests', [RawMaterialRequestController::class, 'index']);
    Route::post('/raw-material-requests', [RawMaterialRequestController::class, 'store']);
    Route::get('/raw-material-requests/{rawMaterialRequest}', [RawMaterialRequestController::class, 'show']);

    Route::middleware('auth:sanctum')->get('/raw-materials', [RawMaterialController::class, 'index']);
    Route::middleware('auth:sanctum')->get(
        '/raw-material-inventory',
        [RawMaterialInventoryController::class, 'index']
    );

    Route::middleware('auth:sanctum')->get('/production-reports', [ProductionReportController::class, 'index']);
    Route::middleware('auth:sanctum')->post('/production-reports', [ProductionReportController::class, 'store']);
    Route::middleware('auth:sanctum')->get('/production-reports/{productionReport}', [ProductionReportController::class, 'show']);

    Route::middleware('auth:sanctum')->get('/products', [ProductController::class, 'index']);
});