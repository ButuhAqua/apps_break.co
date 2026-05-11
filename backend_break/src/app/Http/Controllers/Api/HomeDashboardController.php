<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RawMaterialRequest;
use App\Models\ProductionReport;
use App\Models\RunnerTripReport;
use App\Models\Inventory;
use Illuminate\Http\Request;

class HomeDashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user()->load('employee');

        $role = $user->employee?->role;
        $location = $user->employee?->assigned_location;

        if ($role === 'Unit Produksi') {
            return response()->json([
                'data' => [
                    'pengajuan' => RawMaterialRequest::where('user_id', $user->id)->count(),
                    'produksi' => ProductionReport::where('user_id', $user->id)->count(),
                    'inventory' => Inventory::count(),
                    'berangkat' => 0,
                    'pulang' => 0,
                ],
            ]);
        }

        if ($role === 'Runner') {
            return response()->json([
                'data' => [
                    'pengajuan' => 0,
                    'produksi' => 0,
                    'inventory' => Inventory::where('location', $location)->count(),
                    'berangkat' => RunnerTripReport::where('user_id', $user->id)->count(),
                    'pulang' => RunnerTripReport::where('user_id', $user->id)
                        ->where('status', 'FINISHED')
                        ->count(),
                ],
            ]);
        }

        return response()->json([
            'data' => [
                'pengajuan' => RawMaterialRequest::where('status', 'Menunggu')->count(),
                'produksi' => ProductionReport::count(),
                'inventory' => Inventory::count(),
                'berangkat' => RunnerTripReport::where('status', 'ONGOING')->count(),
                'pulang' => RunnerTripReport::where('status', 'FINISHED')->count(),
            ],
        ]);
    }
}