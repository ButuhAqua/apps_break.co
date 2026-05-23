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
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\RunnerTripController;
use App\Http\Controllers\Api\HomeDashboardController;
use App\Models\ProductStockMovement;
use App\Models\Inventory;


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

    Route::middleware('auth:sanctum')->get('/me', [ProfileController::class, 'me']);

    Route::middleware('auth:sanctum')->group(function () {

        Route::post(
            '/runner-trips/departure',
            [RunnerTripController::class, 'storeDeparture']
        );
    
    });
    Route::middleware('auth:sanctum')->get('/runner-trips', [RunnerTripController::class, 'index']);
    Route::middleware('auth:sanctum')->post('/runner-trips/departure', [RunnerTripController::class, 'storeDeparture']);
    Route::middleware('auth:sanctum')->post('/runner-trips/{runnerTripReport}/return', [RunnerTripController::class, 'storeReturn']);

    Route::middleware('auth:sanctum')->get('/home-dashboard', [HomeDashboardController::class, 'index']);

    Route::post(
        '/raw-material-requests/{rawMaterialRequest}/approve',
        [RawMaterialRequestController::class, 'approve']
    );
    
    Route::post(
        '/raw-material-requests/{rawMaterialRequest}/reject',
        [RawMaterialRequestController::class, 'reject']
    );
    Route::post(
        '/raw-material-requests/{rawMaterialRequest}/complete',
        [RawMaterialRequestController::class, 'complete']
    );
    Route::post(
        '/production-reports/{productionReport}/approve',
        [ProductionReportController::class, 'approve']
    );

    Route::post(
        '/production-reports/{productionReport}/complete',
        [ProductionReportController::class, 'complete']
    );
    
    Route::post(
        '/production-reports/{productionReport}/reject',
        [ProductionReportController::class, 'reject']
    );

    Route::post(
        '/runner-trips/{runnerTripReport}/approve-departure',
        [RunnerTripController::class, 'approveDeparture']
    );
    
    Route::post(
        '/runner-trips/{runnerTripReport}/reject-departure',
        [RunnerTripController::class, 'rejectDeparture']
    );
    
    Route::post(
        '/runner-trips/{runnerTripReport}/approve-return',
        [RunnerTripController::class, 'approveReturn']
    );
    
    Route::post(
        '/runner-trips/{runnerTripReport}/reject-return',
        [RunnerTripController::class, 'rejectReturn']
    );
});