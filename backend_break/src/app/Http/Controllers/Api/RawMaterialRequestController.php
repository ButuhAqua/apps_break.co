<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RawMaterialRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\RawMaterial;

class RawMaterialRequestController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user()->load('employee');

        $query = RawMaterialRequest::with(['items.rawMaterial', 'user'])
            ->latest();

        if ($user->employee?->role === 'Unit Produksi') {
            $query->where('user_id', $user->id);
        }

        $requests = $query->get()
            ->map(function ($request) {
                return [
                    'id' => $request->id,
                    'title' => $request->title,
                    'request_type' => $request->request_type,
                    'priority' => $request->priority,
                    'request_date' => $request->request_date,
                    'notes' => $request->notes,
                    'purchase_location' => $request->purchase_location,
                    'status' => $request->status,
                    'submitted_by' => [
                        'id' => $request->user?->id,
                        'name' => $request->user?->name,
                        'email' => $request->user?->email,
                    ],
                    'items' => $request->items->map(function ($item) {
                        return [
                            'id' => $item->id,
                            'raw_material_id' => $item->raw_material_id,
                            'name' => $item->name,
                            'category' => $item->category,
                            'uom' => $item->uom,
                            'qty' => $item->qty,
                        ];
                    })->values(),
                    'created_at' => $request->created_at,
                    'updated_at' => $request->updated_at,
                ];
            });

        return response()->json($requests);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'request_type' => ['required', 'string', 'max:255'],
            'priority' => ['required', 'string', 'max:255'],
            'request_date' => ['required', 'date'],
            'notes' => ['nullable', 'string'],
            'purchase_location' => ['nullable', 'string', 'max:255'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.raw_material_id' => ['required', 'exists:raw_materials,id'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
        ]);

        $rawMaterialRequest = DB::transaction(function () use ($validated, $request) {
            $rawMaterialRequest = RawMaterialRequest::create([
                'title' => $validated['title'],
                'request_type' => $validated['request_type'],
                'priority' => $validated['priority'],
                'request_date' => $validated['request_date'],
                'notes' => $validated['notes'] ?? null,
                'purchase_location' => $validated['purchase_location'] ?? null,
                'status' => 'Menunggu',
                'user_id' => $request->user()?->id,
            ]);

            foreach ($validated['items'] as $item) {
                $rawMaterial = RawMaterial::findOrFail($item['raw_material_id']);
            
                $rawMaterialRequest->items()->create([
                    'raw_material_id' => $rawMaterial->id,
                    'name' => $rawMaterial->name,
                    'category' => $rawMaterial->category,
                    'uom' => $rawMaterial->uom,
                    'qty' => $item['qty'],
                ]);
            }

            return $rawMaterialRequest->load(['items', 'user']);
        });

        return response()->json([
            'message' => 'Pengajuan bahan baku berhasil dibuat',
            'data' => [
                'id' => $rawMaterialRequest->id,
                'title' => $rawMaterialRequest->title,
                'request_type' => $rawMaterialRequest->request_type,
                'priority' => $rawMaterialRequest->priority,
                'request_date' => $rawMaterialRequest->request_date,
                'notes' => $rawMaterialRequest->notes,
                'purchase_location' => $rawMaterialRequest->purchase_location,
                'status' => $rawMaterialRequest->status,
                'items' => $rawMaterialRequest->items,
            ],
        ], 201);
    }

    public function show(RawMaterialRequest $rawMaterialRequest)
    {
        $rawMaterialRequest->load(['items', 'user']);

        return response()->json($rawMaterialRequest);
    }

    public function approve(
        Request $request,
        RawMaterialRequest $rawMaterialRequest
    ) {
    
        $user = $request->user()->load('employee');
    
        $allowedRoles = ['Manager', 'Owner', 'Admin'];
    
        if (!in_array($user->employee?->role, $allowedRoles)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval'
            ], 403);
        }
    
        $rawMaterialRequest->update([
            'status' => 'Disetujui',
        ]);
    
        return response()->json([
            'message' => 'Pengajuan berhasil disetujui',
            'data' => $rawMaterialRequest,
        ]);
    }
    
    public function reject(
        Request $request,
        RawMaterialRequest $rawMaterialRequest
    ) {
    
        $user = $request->user()->load('employee');
    
        $allowedRoles = ['Manager', 'Owner', 'Admin'];
    
        if (!in_array($user->employee?->role, $allowedRoles)) {
            return response()->json([
                'message' => 'Tidak memiliki akses approval'
            ], 403);
        }
    
        $validated = $request->validate([
            'reason' => 'nullable|string|max:255',
        ]);
    
        $rawMaterialRequest->update([
            'status' => 'Ditolak',
            'notes' => $validated['reason']
                ?? $rawMaterialRequest->notes,
        ]);
    
        return response()->json([
            'message' => 'Pengajuan berhasil ditolak',
            'data' => $rawMaterialRequest,
        ]);
    }
}