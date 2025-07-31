import React, { useState } from 'react';
import Modal from 'react-modal';
import { PhotoProvider, PhotoView } from 'react-photo-view';
import 'react-photo-view/dist/react-photo-view.css';

interface ImageViewerProps {
  imageUrls: string[];
  height?: string;
}

const ImageViewer = ({ imageUrls, height = 'auto' }: ImageViewerProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  // Open the modal with the selected image
  const openModal = (index: number) => {
    setCurrentImageIndex(index);
    setIsOpen(true);
  };

  // Close the modal
  const closeModal = () => {
    setIsOpen(false);
  };

  // Check if imageUrls is an array and contains valid URLs
  if (!Array.isArray(imageUrls) || imageUrls.length === 0) {
    return <div>No images available</div>;
  }

  return (
    <div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-4">
        {imageUrls.map((image, index) => (
          <div
            key={index}
            className="cursor-pointer relative group"
            onClick={() => openModal(index)}
          >
            <img
              src={image}
              alt={`Image ${index + 1}`}
              style={{ height: height }}
              className="w-full object-cover rounded-lg transition-transform transform hover:scale-105 group-hover:shadow-lg"
            />
            <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-10 transition-all duration-200 rounded-lg" />
          </div>
        ))}
      </div>

      {/* Full-screen Modal for Image */}
      <Modal
        isOpen={isOpen}
        onRequestClose={closeModal}
        className="fixed top-0 left-0 right-0 bottom-0 z-50 flex items-center justify-center bg-black bg-opacity-90 p-4"
        overlayClassName="fixed top-0 left-0 right-0 bottom-0 bg-black bg-opacity-90"
        closeTimeoutMS={300}
      >
        <div className="relative w-full h-full flex justify-center items-center">
          <button
            onClick={closeModal}
            className="absolute top-4 right-4 text-white text-3xl z-10 bg-black bg-opacity-50 rounded-full w-10 h-10 flex items-center justify-center hover:bg-opacity-70 transition-all"
            aria-label="Close modal"
          >
            ×
          </button>

          {/* Fullscreen Image with PhotoView */}
          <PhotoProvider>
            <PhotoView src={imageUrls[currentImageIndex]}>
              <img
                src={imageUrls[currentImageIndex]}
                alt={`Full screen ${currentImageIndex + 1}`}
                className="max-w-full max-h-full object-contain rounded-lg"
              />
            </PhotoView>
          </PhotoProvider>
        </div>
      </Modal>
    </div>
  );
};

export default ImageViewer;
