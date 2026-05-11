<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function me(Request $request)
    {
        $user = $request->user()->load('employee');

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'roles' => method_exists($user, 'getRoleNames')
                    ? $user->getRoleNames()
                    : [],

                'employee' => $user->employee ? [
                    'id' => $user->employee->id,
                    'employee_code' => $user->employee->employee_code,
                    'full_name' => $user->employee->full_name,
                    'role' => $user->employee->role,
                    'assigned_location' => $user->employee->assigned_location,
                    'status' => $user->employee->status,
                ] : null,
            ],
        ]);
    }
}