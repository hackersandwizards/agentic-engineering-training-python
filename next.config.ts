import type { NextConfig } from "next";

const nextConfig: NextConfig = {
    assetPrefix: '/proxy/3000',
    allowedDevOrigins: ['*.letskube.com'],
};

export default nextConfig;
