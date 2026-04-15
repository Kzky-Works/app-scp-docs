import 'package:flutter/material.dart';

/// ボトムドック（グラスバー）の共通トークン。
abstract final class GlassDockTokens {
  GlassDockTokens._();

  /// タブ行の高さ（アイコン＋ラベル用のメイン領域）。
  static const double barContentHeight = 56;

  /// 全幅ドック上部の微角丸（0 でプライム系のフラット）。
  static const double fullWidthTopRadius = 0;

  /// ぼかし強度（ultraThinMaterial 近似）。
  static const double blurSigma = 24;

  /// ベースの不透明度係数（ダーク時の白の乗算）。
  static const double materialOpacityDark = 0.85;

  /// 上部エッジライト（グラデーション帯の高さ）。
  static const double edgeLightHeight = 0.5;

  /// アクティブ・グロウ（アイコン直上の発光）の幅・高さ。
  static const double glowWidth = 56;
  static const double glowHeight = 36;

  /// インジケーター移動（スプリング近似）。
  static const SpringDescription indicatorSpring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 26,
  );

  /// アイコンタップ時スケール。
  static const double iconPressScale = 0.9;
  static const double iconOvershootScale = 1.08;
}
