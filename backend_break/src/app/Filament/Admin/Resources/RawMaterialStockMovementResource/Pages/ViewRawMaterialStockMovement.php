<?php

namespace App\Filament\Admin\Resources\RawMaterialStockMovementResource\Pages;

use App\Filament\Admin\Resources\RawMaterialStockMovementResource;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewRawMaterialStockMovement extends ViewRecord
{
    protected static string $resource = RawMaterialStockMovementResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Informasi Mutasi')
                    ->schema([
                        Infolists\Components\TextEntry::make('type')
                            ->label('Tipe'),

                        Infolists\Components\TextEntry::make('rawMaterial.name')
                            ->label('Bahan'),

                        Infolists\Components\TextEntry::make('batch.batch_number')
                            ->label('Batch'),

                        Infolists\Components\TextEntry::make('qty')
                            ->label('Qty'),

                        Infolists\Components\TextEntry::make('uom')
                            ->label('Satuan'),

                        Infolists\Components\TextEntry::make('reference_type')
                            ->label('Reference Type'),

                        Infolists\Components\TextEntry::make('reference_id')
                            ->label('Reference ID'),

                        Infolists\Components\TextEntry::make('notes')
                            ->label('Catatan'),

                        Infolists\Components\TextEntry::make('created_at')
                            ->label('Tanggal')
                            ->dateTime('d M Y H:i'),
                    ])
                    ->columns(2),
            ]);
    }
}