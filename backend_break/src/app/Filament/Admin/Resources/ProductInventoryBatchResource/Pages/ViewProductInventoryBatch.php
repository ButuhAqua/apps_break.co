<?php

namespace App\Filament\Admin\Resources\ProductInventoryBatchResource\Pages;

use App\Filament\Admin\Resources\ProductInventoryBatchResource;
use Filament\Resources\Pages\ViewRecord;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class ViewProductInventoryBatch extends ViewRecord
{
    protected static string $resource =
        ProductInventoryBatchResource::class;

    public function infolist(
        Infolist $infolist
    ): Infolist {

        return $infolist
            ->schema([

                Infolists\Components\Section::make(
                    'Informasi Produk'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'product.name'
                        )
                            ->label('Nama Produk'),

                        Infolists\Components\TextEntry::make(
                            'batch_number'
                        )
                            ->label('Nomor Batch')
                            ->badge()
                            ->color('primary'),

                        Infolists\Components\TextEntry::make(
                            'uom'
                        )
                            ->label('Satuan')
                            ->badge(),

                    ])
                    ->columns(3),

                Infolists\Components\Section::make(
                    'Informasi Produksi'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'production_date'
                        )
                            ->label(
                                'Tanggal Produksi'
                            )
                            ->date('d M Y'),

                        Infolists\Components\TextEntry::make(
                            'expired_date'
                        )
                            ->label(
                                'Tanggal Expired'
                            )
                            ->date('d M Y'),

                        Infolists\Components\TextEntry::make(
                            'expired_status'
                        )
                            ->label(
                                'Status Batch'
                            )
                            ->badge()
                            ->getStateUsing(function (
                                $record
                            ) {

                                if (
                                    $record->qty_remaining <= 0
                                ) {
                                    return 'Habis';
                                }

                                if (
                                    $record->expired_date &&
                                    $record->expired_date->isPast()
                                ) {
                                    return 'Expired';
                                }

                                if (
                                    now()->diffInDays(
                                        $record->expired_date
                                    ) <= 3
                                ) {
                                    return 'Hampir Expired';
                                }

                                return 'Aman';
                            })
                            ->color(fn (
                                string $state
                            ) => match ($state) {

                                'Habis' => 'gray',
                                'Expired' => 'danger',
                                'Hampir Expired' => 'warning',
                                'Aman' => 'success',

                                default => 'gray',
                            }),

                        Infolists\Components\TextEntry::make(
                            'sisa_hari'
                        )
                            ->label(
                                'Sisa Waktu Expired'
                            )
                            ->badge()
                            ->color(function ($record) {

                                if (
                                    $record->expired_date &&
                                    $record->expired_date->isPast()
                                ) {
                                    return 'danger';
                                }

                                if (
                                    now()->diffInDays(
                                        $record->expired_date
                                    ) <= 3
                                ) {
                                    return 'warning';
                                }

                                return 'success';
                            })
                            ->getStateUsing(function (
                                $record
                            ) {

                                if (
                                    !$record->expired_date
                                ) {
                                    return '-';
                                }

                                $getDiff = now()->diff(
                                    $record->expired_date
                                );

                                if (
                                    $record->expired_date->isPast()
                                ) {

                                    return 'Expired ' .

                                        abs($getDiff->days) .
                                        ' hari ' .

                                        $getDiff->h .
                                        ' jam lalu';
                                }

                                return
                                    $getDiff->days .
                                    ' hari ' .

                                    $getDiff->h .
                                    ' jam ' .

                                    $getDiff->i .
                                    ' menit';
                            }),

                    ])
                    ->columns(2),

                Infolists\Components\Section::make(
                    'Informasi Stok'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'qty_in'
                        )
                            ->label('Qty Masuk')
                            ->badge()
                            ->color('success'),

                        Infolists\Components\TextEntry::make(
                            'qty_remaining'
                        )
                            ->label(
                                'Qty Tersisa'
                            )
                            ->badge()
                            ->color(function (
                                $record
                            ) {

                                if (
                                    $record->qty_remaining <= 0
                                ) {
                                    return 'gray';
                                }

                                return 'primary';
                            }),

                        Infolists\Components\TextEntry::make(
                            'inventory.location'
                        )
                            ->label('Lokasi'),

                    ])
                    ->columns(3),

                Infolists\Components\Section::make(
                    'Catatan'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'notes'
                        )
                            ->label('Catatan')
                            ->placeholder(
                                'Tidak ada catatan'
                            ),

                    ]),

                Infolists\Components\Section::make(
                    'Informasi Sistem'
                )
                    ->schema([

                        Infolists\Components\TextEntry::make(
                            'created_at'
                        )
                            ->label('Dibuat')
                            ->dateTime(
                                'd M Y H:i'
                            ),

                        Infolists\Components\TextEntry::make(
                            'updated_at'
                        )
                            ->label('Terakhir Update')
                            ->dateTime(
                                'd M Y H:i'
                            ),

                    ])
                    ->columns(2),
            ]);
    }
}