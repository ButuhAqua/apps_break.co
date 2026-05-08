<?php

namespace App\Filament\Admin\Resources\ProductStockMovementResource\Pages;

use App\Filament\Admin\Resources\ProductStockMovementResource;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewProductStockMovement extends ViewRecord
{
    protected static string $resource = ProductStockMovementResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Informasi Mutasi Produk')
                    ->schema([
                        Infolists\Components\TextEntry::make('type')
                            ->label('Tipe'),

                        Infolists\Components\TextEntry::make('product.name')
                            ->label('Produk'),

                        Infolists\Components\TextEntry::make('qty')
                            ->label('Qty'),

                        Infolists\Components\TextEntry::make('uom')
                            ->label('Satuan'),

                        Infolists\Components\TextEntry::make('from_location')
                            ->label('Dari'),

                        Infolists\Components\TextEntry::make('to_location')
                            ->label('Ke'),

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