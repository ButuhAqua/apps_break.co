<?php

namespace App\Filament\Admin\Resources\RunnerTripReportResource\Pages;

use App\Filament\Admin\Resources\RunnerTripReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewRunnerTripReport extends ViewRecord
{
    protected static string $resource = RunnerTripReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}