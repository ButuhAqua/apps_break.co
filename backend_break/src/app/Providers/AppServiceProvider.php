<?php

namespace App\Providers;

use App\Policies\ActivityPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;
use Livewire\Livewire;
use Spatie\Activitylog\Models\Activity;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(Activity::class, ActivityPolicy::class);
        // Livewire::setUploadLimits(
        //     fileSize: 300 * 1024 * 1024, // 300MB
        //     timeout: 300,
        // );
    }
}
